import React from 'react';

import useAxios, { configure } from 'axios-hooks';
import Axios from 'axios';
import { GenerateForm } from './GenerateForm';
import { Link } from 'react-router-dom';

const axios = Axios.create({
  baseURL: import.meta.env.VITE_BACKEND_URL
});

configure({ axios });

interface Response {
  boards: number[];
}

function Index() {
  const [{ data, loading, error }, refetch] = useAxios<Response>('/boards');

  if (loading) return <p>Loading...</p>;
  if (error) return <p>Error!</p>;

  return (
    <>
      <div className="grid grid-flow-row p-8">
        <div className="bg-blue-500 p-4 text-white">
          <div className="grid grid-flow-col auto-cols-max">
            {data?.boards?.map(id => (
              <>
                <Link to={id.toString()}>
                  <span className="bg-black m-4 p-2">#{id}</span>
                </Link>
              </>
            ))}
          </div>
        </div>
      </div>
      <GenerateForm fetchCallback={() => refetch()} />
    </>
  );
}

export default Index;
