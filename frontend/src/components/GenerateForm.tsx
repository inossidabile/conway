import React from 'react';
import useAxios from 'axios-hooks';
import { AxiosRequestConfig } from 'axios';

interface Body {
  board: {
    width: number;
    height: number;
  };
}

export function GenerateForm({ fetchCallback }: { fetchCallback: () => void }) {
  let width: HTMLInputElement | null;
  let height: HTMLInputElement | null;

  const [, sendPost] = useAxios(
    {
      url: '/boards',
      method: 'post'
    },
    { manual: true }
  );

  const executePost = async (data: AxiosRequestConfig<Body>) => {
    try {
      await sendPost(data);
    } finally {
      fetchCallback();
    }
  };

  return (
    <>
      <form
        onSubmit={e => {
          e.preventDefault();
          executePost({
            data: {
              board: {
                width: parseInt(width?.value || '50'),
                height: parseInt(height?.value || '50')
              }
            }
          });
          width!.value = '';
          height!.value = '';
        }}>
        <div className="px-8 flex items-center w-full max-w-md mb-3 seva-fields formkit-fields">
          <div className="relative w-full mr-3 formkit-field">
            <input
              ref={node => {
                width = node;
              }}
              placeholder="Width"
              className="formkit-input bg-gray-50 border border-gray-300 text-gray-900 text-sm rounded-lg focus:ring-blue-500 focus:border-blue-500 block w-full p-2.5 dark:bg-gray-700 dark:border-gray-600 dark:placeholder-gray-400 dark:text-white dark:focus:ring-blue-500 dark:focus:border-blue-500"></input>
          </div>
          <div className="relative w-full mr-3 formkit-field">
            <input
              ref={node => {
                height = node;
              }}
              placeholder="Width"
              className="formkit-input bg-gray-50 border border-gray-300 text-gray-900 text-sm rounded-lg focus:ring-blue-500 focus:border-blue-500 block w-full p-2.5 dark:bg-gray-700 dark:border-gray-600 dark:placeholder-gray-400 dark:text-white dark:focus:ring-blue-500 dark:focus:border-blue-500"></input>
          </div>
          <button>
            <span className="px-5 py-3 text-sm font-medium text-center text-white bg-blue-700 rounded-lg cursor-pointer hover:bg-blue-800 focus:ring-4 focus:ring-blue-300 dark:bg-blue-600 dark:hover:bg-blue-700 dark:focus:ring-blue-800">
              Submit
            </span>
          </button>
        </div>
      </form>
    </>
  );
}
